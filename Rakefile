require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

PuppetLint::RakeTask.new :lint do |config|	
    config.pattern = ['manifests/*.pp', 'modules/opencontrail_ci/**/*.pp']
    config.fail_on_warnings = true
    config.log_format = "%{path}:%{line} [%{KIND}] %{message}"
    config.disable_checks = ['documentation']
    config.ignore_paths = ["vendor/**/*.pp"]
end

PuppetSyntax.exclude_paths = ["vendor/**/*"]
