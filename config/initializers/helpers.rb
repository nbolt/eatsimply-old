class String
  def to_frac
    if split('/')[1]
      numerator, denominator = split('/').map(&:to_f)
      denominator ||= 1
      (split(' ')[1] && split(' ')[0].to_i || 0) + numerator/denominator
    else
      self.to_f
    end
  end
end

class Object
  def then method=nil
    if block_given?
      self && yield(self)
    else
      if self
        if self.respond_to?(method)
          self.send method
        else
          self[method]
        end
      else
        nil
      end
    end
  end

  def chain *methods
    methods.reduce(self, :then)
  end
end

class RecipeNotFound < Exception
end