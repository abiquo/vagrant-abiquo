require 'pathname'
require 'vagrant_abiquo/plugin'
require 'vagrant_abiquo/helpers/client'

module VagrantPlugins
  module Abiquo
    lib_path = Pathname.new(File.expand_path("../vagrant_abiquo", __FILE__))
    autoload :Actions, lib_path.join("actions")
    autoload :Errors, lib_path.join("errors")

    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end

    I18n.load_path << File.expand_path('locales/en.yml', source_root)
    I18n.reload!
  end
end
