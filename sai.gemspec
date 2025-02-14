# frozen_string_literal: true

SAI_GEM_VERSION = '0.5.0'
SAI_SEMVER = '0.5.0'
SAI_REPO_URL = 'https://github.com/rei-kei/sai-rb'
SAI_HOME_URL = 'https://reikei.org'

Gem::Specification.new do |spec|
  spec.name        = 'sai'
  spec.version     = SAI_GEM_VERSION
  spec.homepage    = SAI_HOME_URL
  spec.authors     = ['Aaron Allen']
  spec.email       = ['hello@aaronmallen.me']
  spec.summary     = 'A powerful color science toolkit for seamless cross-model manipulation.'
  spec.description = 'Sai is a sophisticated color management system built on precise color science principles. It ' \
                     'provides a unified interface across multiple color models (RGB, HSL, CMYK, CIE Lab, Oklab, and ' \
                     'more), allowing operations in any model to intelligently propagate throughout the entire color ' \
                     "ecosystem.\nKey features include cross-model operations, perceptually accurate color " \
                     'comparisons using multiple Delta-E algorithms, accessibility tools for contrast evaluation, ' \
                     "sophisticated color matching, and scientific color analysis with CIE standards support.\nSai " \
                     'empowers developers to work with colors consistently across different environments and ' \
                     'applications. Whether developing design tools, data visualizations, or accessibility-focused ' \
                     'applications, Sai provides both mathematical precision and an intuitive API for sophisticated ' \
                     'color manipulation.'

  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.1'

  spec.files = Dir.chdir(__dir__) do
    Dir['{lib,sig}/**/*', '.yardopts', 'CHANGELOG.md', 'LICENSE', 'README.md']
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
