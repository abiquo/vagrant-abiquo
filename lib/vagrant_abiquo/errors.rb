module VagrantPlugins
  module Abiquo
    module Errors
      class AbiquoError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_abiquo.errors")
      end

      class InvalidStateError < AbiquoError
        error_key(:invalid_state)
      end

      class VDCNotFound < AbiquoError
        error_key(:vdc_not_found)
      end

      class TemplateNotFound < AbiquoError
        error_key(:template_not_found)
      end

      class PowerOffError < AbiquoError
        error_key(:poweroff_error)
      end

      class NetworkError < AbiquoError
        error_key(:network_error)
      end

      class HWprofileEnabled < AbiquoError
        error_key(:hwprofile_enabled)
      end

      class HWProfileNotFound < AbiquoError
        error_key(:hwprofile_not_found)
      end

      class APIStatusError < AbiquoError
        error_key(:api_status)
      end

      class APIFindError < AbiquoError
        error_key(:apifind_error)
      end

      class JSONError < AbiquoError
        error_key(:json)
      end

      class ResultMatchError < AbiquoError
        error_key(:result_match)
      end

      class LocalIPError < AbiquoError
        error_key(:local_ip)
      end
    end
  end
end
