# frozen_string_literal: true

# Controller for all static pages: index, about, contact, etc...
class StaticController < ApplicationController
  layout 'landing'

  def index
    @color_scheme = 'blue darken-3'
  end
end
