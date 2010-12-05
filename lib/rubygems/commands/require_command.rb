require 'rubygems/command'
require 'rubygems/dependency_installer'
require 'rubygems/install_update_options'
require 'rubygems/version_option'
require 'rubygems/spec_fetcher'

class Gem::Commands::RequireCommand < Gem::Command

  include Gem::VersionOption
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

    add_version_option
    add_option('--latest',
               'Get the latest matching version') do |value, options|
      options[:latest] = true
    end

    add_install_update_options

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
        alert_error "Error installing #{gem_name}:\n\t#{e.message}"
        exit_code |= 1
      rescue Gem::GemNotFoundException => e
        show_lookup_failure e.name, e.version, e.errors
        exit_code |= 2
      end
    end
    
    exit(exit_code)

  end
  
  private

  def require_gem(name, version, installer_options)
    if installed_version = gem_uptodate?(name, version)
      say "#{name} (#{installed_version}) is already installed"
    else
      say "Installing #{name} ..."
      install_gem(name, version, installer_options)
    end
  end

  def gem_uptodate?(name, version)
    dependency = Gem::Dependency.new(name, version)
    installed = current_spec(dependency)
    if installed 
      if !options[:latest] || installed.version == latest_available_version_of(dependency)
        installed.version
      end
    end
  end

  def current_spec(dependency)
    Gem.source_index.search(dependency).last
  end
  
  def latest_available_version_of(dependency)
    Gem::SpecFetcher.fetcher.fetch(dependency).map { |x| x.first.version }.max
  end
  
  def install_gem(name, version, installer_options)
    installer = Gem::DependencyInstaller.new(installer_options)
    installer.install(name, version)
    installer.installed_gems.each do |spec|
      say "Installed #{spec.full_name}"
    end
  end
  
end
