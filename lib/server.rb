require 'thin'

module Rack::Utils
  def unescape(s, encoding = Encoding::UTF_8)
      if s.include? "+"
        return s
      else
        URI.decode_www_form_component(s, encoding)
      end
    end
  module_function :unescape
end

module Encumber

  env_mode = ENV['MODE']
  port = ENV['PORT']||3000
  app_directory = ENV['DIRECTORY']||"."
  use_cucapp_source = ENV['USE_CUCAPP_SOURCE']||"yes"

  if env_mode == 'build'
    build_dir = Dir.glob('Build/*.build').first
    raise 'Can not find build directory' if build_dir.nil?
    raise 'Can not determine Cappuccino application name' if build_dir.match(/Build\/(.*)\.build/).nil?
    app_name = $1

    if File.exists?('Build/Debug')
      mode = 'Debug'
    else
      mode = 'Release'
    end

    APP_DIRECTORY = "Build/#{mode}/#{app_name}"
  else
    APP_DIRECTORY = app_directory
  end

  raise "Can not locate built application directory: #{APP_DIRECTORY}" if !File.exists?(APP_DIRECTORY)

  n = 0

  bundle = File.join(File.dirname(__FILE__), 'Build', 'Debug', 'Cucumber')
  if !File.exists?(bundle)
    bundle = File.join(File.dirname(__FILE__), 'Plugin', 'Cucumber')
  end
  CUCUMBER_BUNDLE_DIR = bundle

  CUCUMBER_REQUEST_QUEUE = EM::Queue.new
  CUCUMBER_RESPONSE_QUEUE = EM::Queue.new

  MAIN_THREAD = Thread.current

  class DeferrableBody
    include EventMachine::Deferrable

    def call(body)
      body.each do |chunk|
        @body_callback.call(chunk)
      end
    end

    def each(&blk)
      @body_callback = blk
    end
  end

  class CucumberAdapter
    AsyncResponse = [-1, {}, []].freeze

    def call(env)
      if env['REQUEST_METHOD']=='GET'
        body = DeferrableBody.new

        # Get the headers out there asap, let the client know we're alive...
        EM.next_tick do
          env['async.callback'].call [200, {'Content-Type' => 'text/plain'}, body]

          CUCUMBER_REQUEST_QUEUE.pop { |req|
            body.call [req.to_json]
            body.succeed
          }
        end

        AsyncResponse
      else
        CUCUMBER_RESPONSE_QUEUE.push env
        result = {:result => :ok}

        body = [result.to_json]
        [
          200,
          { 'Content-Type' => 'text/plain' },
          body
        ]
      end
    end
  end

  if env_mode == 'debug'
    html = File.read(File.join(APP_DIRECTORY, 'index-debug.html'))
  else
    html = File.read(File.join(APP_DIRECTORY, 'index.html'))
  end

  html.gsub!(/<title>(.*)<\/title>/) do
    "<title>#{$1} - Cucumber</title>"
  end

  html.gsub!(/<\/body>/) do
    <<-END_OF_JS
      <script type="text/javascript">
        function startCucumber() {
          if(window['CPApp'] && CPApp._finishedLaunching) {

            if ("#{use_cucapp_source}" == "yes")
            {
              objj_importFile("/Cucapp/lib/Cucumber.j");
              setTimeout(function(){
              objj_importFile("/features/support/CucumberCategories.j");},0);
            }
            else
            {
              var bundle = new CFBundle("/Cucumber/Bundle/");

              bundle.addEventListener("load", function()
              {
                objj_importFile("/features/support/CucumberCategories.j");
              });

              bundle.load(YES);
            }
          } else {
            window.setTimeout(startCucumber, 100);
          }
        }
        window.setTimeout(startCucumber, 100);
      </script>
    </body>
END_OF_JS
  end

  File.open(File.join(APP_DIRECTORY, 'cucumber.html'), 'w') {|f| f.write(html) }

  class MyThread < Thread

  end

  # This makes gourd crash on linux.
  # Thin::Logging.debug = false

  MyThread.new{
    EM.run {
      cucumber = Rack::URLMap.new(
        '/cucumber' => CucumberAdapter.new,
        '/Cucumber/Bundle' => Rack::Directory.new(CUCUMBER_BUNDLE_DIR),
        '/' => Rack::Directory.new(APP_DIRECTORY)
      )

      Thin::Server.start('0.0.0.0', port) {
	      puts "Starting server"
        run(cucumber)
        puts "RESTARTING main thread"
        Encumber::MAIN_THREAD.wakeup
      }
    }
  }
  Thread.stop
end
