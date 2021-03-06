require 'rubygems/command'
require 'rubygems/dependency_installer'
require 'rubygems/install_update_options'
require 'rubygems/local_remote_options'
require 'rubygems/version_option'
require 'rubygems/spec_fetcher'

class Gem::Commands::RequireCommand < Gem::Command

  include Gem::VersionOption
  include Gem::LocalRemoteOptions
  include Gem::InstallUpdateOptions

  def initialize
    defaults = Gem::DependencyInstaller::DEFAULT_OPTIONS.merge(
    {
      :generate_rdoc     => true,
      :generate_ri       => true,
      :format_executable => false,
      :test              => false,
      :version           => Gem::Requirement.default,
      :latest            => false,
    }
    )

    super 'require', 'Install or update a gem', defaults

    add_option('--latest',
               'Get the latest matching version') do |value, options|
      options[:latest] = true
    end

    add_install_update_options
    add_local_remote_options

    add_version_option
    add_platform_option
    add_prerelease_option

  end

  def arguments # :nodoc:
    "GEMNAME       name of required gem"
  end

  def defaults_str # :nodoc:
    "--version '#{Gem::Requirement.default}' --rdoc --ri --no-force\n" \
    "--no-test --install-dir #{Gem.dir}"
  end

  def description # :nodoc:
    <<-EOF
The require command checks whether the specified gems are installed,
and installs them if necessary.
    EOF
  end

  def usage # :nodoc:
    "#{program_name} GEMNAME [GEMNAME ...] [options]"
  end

  def execute
    exit_code = 0

    version = options[:version]
    get_all_gem_names.each do |name|
      begin
        require_gem(name, version, options)
      rescue Gem::InstallError => e
        alert_error "Error installing #{name}:\n\t#{e.message}"
        exit_code |= 1
      rescue Gem::GemNotFoundException => e
        show_lookup_failure e.name, e.version, e.errors, options[:domain]
        exit_code |= 2
      end
    end

    exit(exit_code)

  end

  private

  def require_gem(name, version, installer_options)

    dependency = Gem::Dependency.new(name, version)
    installed = latest_installed_version_of(dependency)

    if installed && options[:latest]
      latest_version = latest_available_version_of(dependency)
      if installed.version < latest_version
        installed = nil
        version = latest_version
      end
    end

    if installed
      say "#{name} (#{installed.version}) is already installed"
    else
      say "Installing #{name} (#{version}) ..."
      install_gem(name, version, installer_options)
    end

  end

  def latest_installed_version_of(dependency)
    if dependency.respond_to?(:matching_specs)
      # Rubygems 1.8+
      dependency.matching_specs.last
    else
      Gem.source_index.search(dependency).last
    end
  end

  def matching_tuples(dependency)
    fetcher = Gem::SpecFetcher.fetcher
    if fetcher.respond_to?(:search_for_dependency)
      fetcher.search_for_dependency(dependency).first
    else
      fetcher.fetch(dependency)
    end
  end

  def latest_available_version_of(dependency)
    matching_tuples(dependency).map { |x| x.first.version }.max
  end

  def install_gem(name, version, installer_options)
    installer = Gem::DependencyInstaller.new(installer_options)
    installer.install(name, version)
    installer.installed_gems.each do |spec|
      say "Installed #{spec.full_name}"
    end
  end

end
