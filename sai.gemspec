# frozen_string_literal: true

SAI_GEM_VERSION = '0.5.0.dev.26'
SAI_SEMVER = '0.5.0-dev.26'
SAI_REPO_URL = 'https://github.com/sai-lib/sai-rb'
SAI_HOME_URL = 'https://sai-lib.com'

Gem::Specification.new do |spec|
  spec.name        = 'sai'
  spec.version     = SAI_GEM_VERSION
  spec.homepage    = SAI_HOME_URL
  spec.authors     = ['Aaron Allen']
  spec.email       = ['hello@aaronmallen.me']
  spec.summary     = 'A powerful color science toolkit.'
  spec.description = 'Coming Soon'

  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.1'

  spec.files = Dir.chdir(__dir__) do
    Dir['{lib}/**/*', '.yardopts', 'CHANGELOG.md', 'LICENSE', 'README.md']
      .reject { |f| File.directory?(f) }
  end

  spec.require_paths = ['lib']

  spec.metadata = {
    'bug_tracker_uri' => "#{SAI_REPO_URL}/issues",
    'changelog_uri' => "#{SAI_REPO_URL}/releases/tag/#{SAI_SEMVER}",
    'homepage_uri' => spec.homepage,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => "#{SAI_REPO_URL}/tree/#{SAI_SEMVER}",
  }
end
