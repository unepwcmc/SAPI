##
# See also Deletable.
#
# This module defines methods used by Deletable in order to determine if records
# can be deleted safely, prior to attempting deletion.
#
# TODO: replace the manually-curated `dependent_objects_map` with introspection
# of ActiveRecord's built-in associations, looking for `has_one`/`has_many`
# associations which don't have `dependant: destroy` or `dependant: nullify`.
module ProtectedDeletion
  extend ActiveSupport::Concern

  # ideally override this
  def can_be_deleted?
    dependent_objects.empty?
  end

  ##
  # used to return informative error message on failed destroy
  #
  # Returns a list of human-readable names of associations, which are the
  # keys of dependent_objects_map, where those associations have 1 or more
  # rows in the db.
  def dependent_objects
    dependent_objects_map.map do |k, v|
      v.limit(1).count > 0 ? k : nil
    end.compact
  end

protected

  ##
  # returns hash that maps the displayable name of a dependency
  # to a relation that returns dependent objects
  # e.g. for an object that has_many :foos:
  # {'amazingly important Foos' => foos}
  def dependent_objects_map
    {}
  end
end
