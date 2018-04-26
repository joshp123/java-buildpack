# Encoding: utf-8
# Cloud Foundry Java Buildpack
# Copyright 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fileutils'
require 'java_buildpack/component/base_component'
require 'java_buildpack/framework'

module JavaBuildpack
  module Framework

    # Encapsulates the functionality for enabling zero-touch Sentry support.
    class SentryAgent < JavaBuildpack::Component::BaseComponent

      def initialize(context, &version_validator)
        super(context, &version_validator)
        @component_name = 'Sentry Agent'
      end


      # (see JavaBuildpack::Component::BaseComponent#detect)
      def detect
          @application.environment.key?('SENTRY_DSN')
      end

      # (see JavaBuildpack::Component::BaseComponent#compile)
      def compile
        sentry_agent_uri = 'https://github.com/getsentry/sentry-java/releases/download/v1.7.3/libsentry_agent_linux-x86_64.so'
        sentry_version = '1.7.3'
        print('compilez')
        download(sentry_version, sentry_agent_uri) do | file |
            FileUtils.mv(file.path, @droplet.sandbox + 'sentry.so')
            puts('yes more')
        end
      end

      # (see JavaBuildpack::Component::BaseComponent#release)
      def release
        @droplet.java_opts
            .add_javaagent(@droplet.sandbox + 'sentry.so')
      end

      protected

      # (see JavaBuildpack::Component::VersionedDependencyComponent#supports?)
      def supports?
        return true
        # sentry_configured?(@application.root) || sentry_configured?(@application.root + 'WEB-INF/classes')
      end

      private

      def sentry_configured?(root_path)
        (root_path + 'rebel.xml').exist? && (root_path + 'rebel-remote.xml').exist?
      end

      def download_location
        @droplet.sandbox + 'sentry'
      end

    end

  end
end
