module CiteMakor
  module Utils
    class << self

      # adapted from Rails
      def word_wrap(text, line_width: 80, break_sequence: "\n")
        regex =
          if text.match?(/[א-ת]/)
            /(([א-ת][^א-ת]*){1,80})(\s+|$)/
          else
            /(.{1,#{line_width}})(\s+|$)/
          end
        text.split("\n").collect! do |line|
          line.length > line_width ? line.gsub(regex, "\\1#{break_sequence}").rstrip : line    end * break_sequence
      end

      def line_length(line)
        if line.match?(/[א-ת]/)
          line.scan(/[א-ת]/).size
        else
          line.length
        end
      end
    end
  end
end
