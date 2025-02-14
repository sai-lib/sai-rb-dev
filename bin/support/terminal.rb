# frozen_string_literal: true

module Sai
  module CLI
    module Support
      module Terminal
        COLORS = {
          bright_white: "38;2;255;255;255",
          error: "38;2;249;38;114",
          info: "38;2;102;217;239",
          warn: "38;2;253;151;30",
          success: "38;2;166;226;47",
        }

        STYLES = {
          bold: "1",
          faint: "2",
          italic: "3",
          underline: "4",
        }

        private

        def ansi(*codes, text)
          codes = codes.map { |code| COLORS[code] || STYLES[code] || '' }.join(';')
          "\e[#{codes}m#{text}\e[0m"
        end

        def ask(message, default: nil)
          output = if default
                     "#{ansi(:info, message)} #{ansi(:faint, " [#{default}]")}: "
                   else
                     "#{ansi(:info, message)}:"
                   end
          print output
          input = gets.chomp
          input.empty? ? default : input
        end

        def ask_yes_no(message, default: nil)
          valid_answers = %w[n no y yes]
          unless default.nil? || valid_answers.include?(default)
            raise ArgumentError, "default must be 'yes', 'y', 'no', or 'n'"
          end

          output = "#{ansi(:info, message)} #{ansi(:faint, " [(y)es/(n)o]")}: "
          print output
          input = gets.chomp
          input = input.empty? ? default : input.downcase

          if valid_answers.include?(input)
            %w[yes y].include?(input)
          else
            print "\n#{ansi(:warn, :bold, 'please answer (y)es/(n)o')}\n"
            ask_yes_no(message, default: default)
          end
        end

        def error!(message)
          output = "#{ansi(:bright_white, :bold, '[')}"
          output += "#{ansi(:error, :bold,'ERROR')}"
          output += "#{ansi(:bright_white, :bold, ']')}"
          output += " #{message}"
          warn output
          exit 1
        end

        def success(message)
          output = "#{ansi(:bright_white, :bold, '[')}"
          output += "#{ansi(:success, :bold,'SUCCESS')}"
          output += "#{ansi(:bright_white, :bold, ']')}"
          output += " #{message}"
          print output
        end

        def warning(message)
          output = "#{ansi(:bright_white, :bold, '[')}"
          output += "#{ansi(:warn, :bold,'WARNING')}"
          output += "#{ansi(:bright_white, :bold, ']')}"
          output += " #{message}"
          warn output
        end
      end
    end
  end
end
