class Species::SearchSerializer < ActiveModel::Serializer
  attributes :id, :results, :result_cnt, :total_cnt
end
