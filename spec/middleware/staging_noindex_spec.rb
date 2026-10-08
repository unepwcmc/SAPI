require 'spec_helper'

describe StagingNoindex do
  let(:downstream_headers) { { 'Content-Type' => 'text/html' } }
  let(:app) { ->(_env) { [200, downstream_headers, ['body']] } }
  let(:middleware) { described_class.new(app) }

  def get(path, method: 'GET')
    middleware.call('PATH_INFO' => path, 'REQUEST_METHOD' => method)
  end

  describe 'the noindex header' do
    it 'is set on application responses' do
      _status, headers, _body = get('/species')

      expect(headers['X-Robots-Tag']).to eq('noindex, nofollow, noarchive, nosnippet')
    end

    it 'leaves the downstream response otherwise intact' do
      status, headers, body = get('/species')

      expect(status).to eq(200)
      expect(headers['Content-Type']).to eq('text/html')
      expect(body).to eq(['body'])
    end
  end

  describe 'robots.txt' do
    it 'is served by the middleware rather than from public/' do
      status, _headers, body = get('/robots.txt')

      expect(status).to eq(200)
      expect(body.join).to include("User-agent: *\nAllow: /")
    end

    # Disallowing would stop Googlebot fetching the pages, and it has to fetch
    # them to see the noindex header that removes them from the index.
    it 'allows crawling so the noindex header can be read' do
      _status, _headers, body = get('/robots.txt')

      expect(body.join).not_to include('Disallow:')
    end

    it 'does not leak production rules or the production sitemap' do
      _status, _headers, body = get('/robots.txt')

      expect(body.join).not_to include('sitemap.xml.gz')
      expect(body.join).not_to include('Allow: /cites_trade')
    end

    it 'carries the noindex header too' do
      _status, headers, _body = get('/robots.txt')

      expect(headers['X-Robots-Tag']).to eq('noindex, nofollow, noarchive, nosnippet')
    end

    it 'sets a byte-accurate Content-Length' do
      _status, headers, body = get('/robots.txt')

      expect(headers['Content-Length']).to eq(body.join.bytesize.to_s)
    end

    it 'answers HEAD as well as GET' do
      status, _headers, _body = get('/robots.txt', method: 'HEAD')

      expect(status).to eq(200)
    end

    it 'does not intercept other verbs' do
      _status, headers, body = get('/robots.txt', method: 'POST')

      expect(body).to eq(['body'])
      expect(headers['X-Robots-Tag']).to eq('noindex, nofollow, noarchive, nosnippet')
    end
  end
end
