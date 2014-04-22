module ProtectedDeletion

  # ideally override this
  def can_be_deleted?
    dependent_objects.empty?
  end

  # used to return informative error message on failed destroy
  def dependent_objects
    dependent_objects_map.map do |k, v|
      v.limit(1).count > 0 ? k : nil
    end.compact
  end

  protected

  # returns hash that maps the displayable name of a dependency
  # to a relation that returns dependent objects
  # e.g. for an object that has_many :foos:
  # {'amazingly important Foos' => foos}
  def dependent_objects_map
    {}
  end

end
ActiveRecord::Base.send :include, ProtectedDeletion
