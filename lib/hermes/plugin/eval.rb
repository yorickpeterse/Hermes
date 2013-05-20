module Hermes
  module Plugin
    ##
    # Evaluates code using <http://eval.in/>.
    #
    class Eval
      include Cinch::Plugin

      set :help => 'eval [LANGUAGE] [CODE] - Evaluates the given code ' \
        'using http://eval.in',
        :plugin_name => 'eval'

      ##
      # The URL of the "API".
      #
      # @return [String]
      #
      URL = 'http://eval.in/'

      ##
      # Shortcuts for common languages.
      #
      # @return [Hash]
      #
      LANGUAGES = {
        'ruby'    => 'ruby/mri-2.0.0',
        'ruby19'  => 'ruby/mri-1.9.3',
        'ruby18'  => 'ruby/mri-1.8.7',
        'python'  => 'python/cpython-3.2.3',
        'python2' => 'python/cpython-2.7.3'
      }

      match(/eval\s+(\S+)\s+(.+)/)

      ##
      # Submits the code and displays the output + URL in the IRC channel.
      #
      # @param [Cinch::Message] message
      # @param [String] language
      # @param [String] code
      #
      def execute(message, language, code)
        if LANGUAGES.key?(language)
          language = LANGUAGES[language]
        else
          message.reply(
            "Unsupported language: #{language}, supported languages: " \
              "#{supported_languages}",
            true
          )

          return
        end

        begin
          fields   = {:lang => language, :code => code, :execute => '1'}
          response = Hermes.http.post(URL, :body => fields)
        rescue => error
          message.reply("Failed to submit the code: #{error.message}", true)

          return
        end

        url = response.headers['Location'].to_s

        if response.code == 302 and !url.empty?
          response, json = Hermes.http.get_json(url + '.json')
          output         = json['output'].split("\n")[0]

          message.reply("=> #{output} | #{url}", true)
        else
          message.reply(
            "The eval.in server shat itself. HTTP status: #{response.code}",
            true
          )
        end
      end

      private

      ##
      # @return [String]
      #
      def supported_languages
        return LANGUAGES.keys.join(', ')
      end
    end # Eval
  end # Plugin
end # Hermes
