require 'pathname'
require 'vagrant_abiquo/plugin'

module VagrantPlugins
  module Abiquo
    lib_path = Pathname.new(File.expand_path("../vagrant_abiquo", __FILE__))
    autoload :Actions, lib_path.join("actions")
    autoload :Errors, lib_path.join("errors")

    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end
