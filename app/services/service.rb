# frozen_string_literal: true

module Service
  extend ActiveSupport::Concern

  module ClassMethods
    def call(*args, &block)
      new(*args).call(&block)
    end
  end

  def call(*args, &block)
    new(*args).call(&block)
  end
end
