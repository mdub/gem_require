require 'rubygems/command'
require 'rubygems/dependency_installer'
require 'rubygems/install_update_options'
require 'rubygems/version_option'

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
    }
    )

    super 'require', 'Install or update a gem', defaults

    add_install_update_options
    add_version_option

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
  
  def require_gem(name, version, installer_options)

    dependency = Gem::Dependency.new(name, version)

    if !Gem.source_index.search(dependency).empty?
      say "#{dependency} is already installed"
      return false
    end

    say "Installing #{dependency} ..."

    installer = Gem::DependencyInstaller.new(installer_options)
    installer.install(name, version)

    installer.installed_gems.each do |spec|
      say "Installed #{spec.full_name}"
    end
  end

end
