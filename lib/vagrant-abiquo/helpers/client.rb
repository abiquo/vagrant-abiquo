require 'vagrant-abiquo/helpers/result'
require 'rest-client'
require 'json'
require 'log4r'
include Log4r

module VagrantPlugins
  module Abiquo
    module Helpers
      module Client
        def client
          @client ||= ApiClient.new(@machine)
        end
      end

      class ApiClient
        include Vagrant::Util::Retryable

        def initialize(machine)
          @timeout = 60
          @otimeout = 30
          @logger = Log4r::Logger.new('vagrant::abiquo::apiclient')
          @config = machine.provider_config
        end

        def find_id(entity,entity_collection,name)
          JSON.parse(entity_collection)['collection'].each do |collection|
            if collection['name'] == name               
              return collection['id'].to_s
            end
          end
          raise(Errors::APIFindError, {
              :entity => entity,
              :name => name
            })
        end

        def find_template(entity,entity_collection,name)
          JSON.parse(entity_collection)['collection'].each do |collection|
            if collection['name'] == name
              collection['links'].each do |template_link|
                if template_link['rel'] == "edit"
                  return template_link['href']
                end
              end
            end
          end
          raise(Errors::APIFindError, {
              :entity => entity,
              :name => name
            })
        end

        # TO-DO
        # Crear metodos de FIND_VDC / FIND_VAPP / FIND_VM y eliminarlos de create y provider
        #
        def http_request(resource, method, headers={}, data={})
          begin
            req = RestClient::Resource.new( resource, :user => @config.abiquo_api_user, :password => @config.abiquo_api_password, :timeout => @timeout, :open_timeout => @otimeout )
            case method
              when "GET"
                if headers.nil? then
                  res = req.get
                else
                  res = req.get(headers)
                end
              when "POST"
                if headers.nil? then
                  res = req.post
                else
                  res = req.post(data,headers)
                end
            end
          rescue => e
            raise(Errors::RestClientError, {
              :path => resource,
              :headers => headers,
              :data => data,
              :response => e.to_s
            })
          end
          if res.code == 202 or 
             res.code == 201 or 
             res.code == 200 then
               return res.body
          end
        end

#        def request(path, params = {})
#          begin
#            @logger.info "Request: #{path}"
#            result = @client.get(path, params = params.merge({
#              :client_id => @config.client_id,
#              :api_key => @config.api_key
#            }))
#          rescue Faraday::Error::ConnectionFailed => e
#            # TODO this is suspect but because farady wraps the exception
#            #      in something generic there doesn't appear to be another
#            #      way to distinguish different connection errors :(
#            if e.message =~ /certificate verify failed/
#              raise Errors::CertificateError
#            end
#
#            raise e
#          end

#          # remove the api key in case an error gets dumped to the console
#          params[:api_key] = 'REMOVED'

#          begin
#            body = JSON.parse(result.body)
#            @logger.info "Response: #{body}"
#          rescue JSON::ParserError => e
#            raise(Errors::JSONError, {
#              :message => e.message,
#              :path => path,
#              :params => params,
#              :response => result.body
#            })
#          end

#          if body['status'] != 'OK'
#            raise(Errors::APIStatusError, {
#              :path => path,
#              :params => params,
#              :status => body['status'],
#              :response => body.inspect
#            })
#          end

#          Result.new(body)
#        end

#        def wait_for_event(env, id)
#          retryable(:tries => 120, :sleep => 10) do
#            # stop waiting if interrupted
#            next if env[:interrupted]

            # check event status
#            result = self.request("/events/#{id}")

#            yield result if block_given?
#            raise 'not ready' if result['event']['action_status'] != 'done'
#          end
#        end
      end
    end
  end
end
