# frozen_string_literal: true

require 'csv'
require 'json'
require 'yaml'

module Sai
  module Core
    class DataStore
      include Concurrency

      DEFAULT_DATA_DIRECTORIES = [
        File.expand_path('../data', File.dirname(__FILE__)).freeze,
      ].freeze
      private_constant :DEFAULT_DATA_DIRECTORIES

      def initialize(*directories)
        @directories = DEFAULT_DATA_DIRECTORIES

        directories.each { |dir| self << dir }
      end

      def exist?(path)
        !find(path).nil?
      end

      def find(path)
        directory = @directories.find { |dir| File.exist?(File.join(dir, path)) }
        return unless directory

        File.join(directory, path)
      end

      def load(path, **options)
        file = find(path)
        raise ArgumentError, "Unable to find data file #{path}" unless file

        Sai.cache.fetch(DataStore, :load, file) do
          case File.extname(file)
          when '.csv'
            begin
              CSV.parse(File.read(file), **options)
            rescue CSV::MalformedCSVError => e
              raise InvalidDataFileError, "Failed to parse CSV: #{e.message}"
            end
          when '.json'
            begin
              JSON.load_file(file, **options)
            rescue JSON::ParserError => e
              raise InvalidDataFileError, "Failed to parse JSON: #{e.message}"
            end
          when '.yml', '.yaml'
            begin
              YAML.load_file(file, **options)
            rescue Psych::Exception => e
              raise InvalidDataFileError, "Failed to parse YAML: #{e.message}"
            end
          else
            raise InvalidDataFileError, "Unsupported data file type #{File.extname(file)}"
          end
        rescue Errno::ENOENT
          raise InvalidDataFileError, "Data file not found: #{path}"
        rescue Errno::EACCES, Errno::EPERM
          raise InvalidDataFileError, "Permission denied: #{path}"
        rescue IOError
          raise InvalidDataFileError, "I/O error reading file: #{path}"
        end
      end

      def register_directory(directory)
        raise ArgumentError, "Data directory #{directory} not found" unless Dir.exist?(directory)

        mutex.synchronize { @directories = @directories.dup.push(directory).compact.uniq.freeze }
      end
      alias << register_directory
    end
  end
end
