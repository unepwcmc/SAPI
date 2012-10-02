# == Schema Information
#
# Table name: annotations
#
#  id            :integer          not null, primary key
#  symbol        :string(255)
#  parent_symbol :string(255)
#

class Annotation < ActiveRecord::Base
  attr_accessible :symbol, :parent_symbol
end
