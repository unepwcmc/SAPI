require 'spec_helper'

describe Api::V1::IntertaxonomicMappingsController do
  let(:cites) { MatchableTaxonomy.create!(code: 'CITES_EU', name: 'CITES / EU') }
  let(:iucn) { MatchableTaxonomy.create!(code: 'IUCNRL', name: 'IUCN Red List') }
  let(:kew) { MatchableTaxonomy.create!(code: 'Kew', name: 'Kew / WCSP') }

  def taxon(taxonomy, nid, name, author: nil)
    MappingTaxon.create!(
      matchable_taxonomy: taxonomy, taxon_nid: nid, accepted_taxon_nid: nid,
      name_status: 'A', scientific_name: name, author_year: author, source_file: 't.csv'
    )
  end

  def match(foreign_nid, statuses:, confidence:, foreign: iucn, name: 'n', foreign_name: 'n')
    MappingMatch.create!(
      matchable_taxonomy: cites, taxon_nid: '68363',
      foreign_matchable_taxonomy: foreign, foreign_taxon_nid: foreign_nid,
      matched_name: name, matched_name_status: statuses[0],
      foreign_matched_name: foreign_name, foreign_matched_name_status: statuses[1],
      match_confidence: confidence, source_file: 'f.csv'
    )
  end

  def fetch(id = 'CITES_EU:68363', **params)
    get :show, params: { id: id, **params }
    response.parsed_body
  end

  before do
    taxon(cites, '68363', 'Chelonoidis niger', author: '(Quoy & Gaimard, 1824)')
    taxon(iucn, '9023', 'Chelonoidis niger')
    taxon(iucn, '9017', 'Chelonoidis abingdonii')
    taxon(iucn, '9025', 'Chelonoidis microphyes')
  end

  it 'describes the taxon asked about' do
    expect(fetch['taxon']).to eq(
      'taxonomy' => 'CITES_EU', 'taxon_nid' => '68363',
      'scientific_name' => 'Chelonoidis niger', 'author_year' => '(Quoy & Gaimard, 1824)'
    )
  end

  it 'returns every match, ranked on match type before confidence' do
    # The direct match wins although its bridged siblings score higher - the
    # AA pass cannot score above `high`.
    match('9025', statuses: 'SS', confidence: 'really high')
    match('9017', statuses: 'SA', confidence: 'really high')
    match('9023', statuses: 'AA', confidence: 'high')

    expect(fetch['mappings'].map { |m| [ m['taxon_nid'], m['rank'] ] })
      .to eq [ [ '9023', 1 ], [ '9017', 2 ], [ '9025', 3 ] ]
  end

  it 'breaks ties on the accepted name' do
    match('9023', statuses: 'SA', confidence: 'high')
    match('9017', statuses: 'SA', confidence: 'high')

    expect(fetch['mappings'].pluck('scientific_name'))
      .to eq [ 'Chelonoidis abingdonii', 'Chelonoidis niger' ]
  end

  it 'ranks each platform on its own, in a flat list ordered by platform' do
    taxon(kew, 'k1', 'Chelonoidis niger')
    match('k1', statuses: 'SS', confidence: 'low', foreign: kew)
    match('9023', statuses: 'AA', confidence: 'high')

    expect(fetch['mappings'].map { |m| [ m['taxonomy'], m['rank'] ] })
      .to eq [ [ 'IUCNRL', 1 ], [ 'Kew', 1 ] ]
  end

  it 'carries the provenance of each match, without the source file' do
    match('9017', statuses: 'SA', confidence: 'really high', name: 'Testudo abingdonii', foreign_name: 'Chelonoidis abingdonii')

    expect(fetch['mappings'].first).to eq(
      'taxonomy' => 'IUCNRL', 'taxon_nid' => '9017',
      'scientific_name' => 'Chelonoidis abingdonii', 'author_year' => nil,
      'rank' => 1, 'match_type' => 'SA', 'match_confidence' => 6,
      'matched_name' => 'Testudo abingdonii', 'foreign_matched_name' => 'Chelonoidis abingdonii'
    )
  end

  it 'narrows to the platforms asked for' do
    taxon(kew, 'k1', 'Chelonoidis niger')
    match('k1', statuses: 'AA', confidence: 'high', foreign: kew)
    match('9023', statuses: 'AA', confidence: 'high')

    expect(fetch(taxonomies: 'Kew').dig('mappings', 0, 'taxonomy')).to eq 'Kew'
  end

  it 'answers an unmatched taxon with an empty list' do
    expect(fetch['mappings']).to eq []
  end

  it 'answers a taxon it does not hold rather than refusing it' do
    # The taxa exports are not a complete record of each platform.
    body = fetch('CITES_EU:404')

    expect([ response.status, body.dig('taxon', 'scientific_name'), body['mappings'] ]).to eq [ 200, nil, [] ]
  end

  it 'accepts a taxon id containing a dot' do
    taxon(cites, '12.3', 'Dotted')

    expect(fetch('CITES_EU:12.3').dig('taxon', 'scientific_name')).to eq 'Dotted'
  end

  it 'is not found for an unknown platform in the path' do
    fetch('NOPE:1')

    expect(response).to have_http_status :not_found
  end

  it 'is not found for an unknown platform in the filter' do
    fetch(taxonomies: 'IUCNRL,NOPE')

    expect(response).to have_http_status :not_found
  end

  it 'is a bad request without a taxon id' do
    fetch('CITES_EU')

    expect(response).to have_http_status :bad_request
  end
end
