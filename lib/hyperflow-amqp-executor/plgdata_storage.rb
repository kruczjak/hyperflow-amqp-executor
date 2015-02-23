require 'httpclient'
require 'pry'

module Executor
  module PLGDataStorage
    PLGDATA_ENDPOINT = (ENV['PLGDATA_ENDPOINT'] or 'https://data.plgrid.pl')
    def storage_init
      @http_client = HTTPClient.new()
      @http_client.ssl_config.add_trust_ca("plgdata.pem") # Add cert chain to OpenSSL
      
      raise Exception, "Unable to load proxy certificate" unless File.exists?(Executor::settings.plgdata.proxy)
      @proxy_string = File.read(Executor::settings.plgdata.proxy)
    end

    def stage_in
      @job.inputs.each do |file|
          local_file_name = @workdir+"/"+file.name
          url = PLGDATA_ENDPOINT+'/download/'+@job.options.prefix+file.name
          Executor::logger.debug "[#{@id}] Downloading #{url} to #{local_file_name}"
          payload = {proxy: @proxy_string}

          File.open(local_file_name, File::RDWR|File::CREAT) do |local_file|
            response = @http_client.get(url, payload) do |chunk|
              local_file.write(chunk)
            end
            raise Exception, "Failed downloading input file" unless response.ok?
          end
      end
    end

    def stage_out
      @job.outputs.each do |file|
        url = PLGDATA_ENDPOINT+'/upload/' + @job.options.prefix + File.dirname(file.name)

        Executor::logger.debug "[#{@id}] Uploading #{file.name} to #{url}"
        local_file_name = @workdir+"/"+file.name

        File.open(local_file_name) do |local_file|
          payload = {proxy: @proxy_string, file: local_file}
          response = @http_client.post(url, payload)
          raise Exception, "Failed uploading output file: #{response.content}" unless response.ok?
        end
      end
    end

    def workdir(&block)
      Dir::mktmpdir(&block)
    end
  end
end