#!/usr/bin/env ruby
# encoding: UTF-8

require 'find'
require 'pathname'
require 'pp'
require 'uri'

starting_dir = if ARGV.length > 0 then ARGV[0] else "." end

def to_repo_hash(path)
  content = File.read(path)
  {
    path: path,
    content: content,
    name: content.match('^\[(.+)\]$')[1],
    baseurl: content.match('^baseurl=(.+)$', )[1],
    priority: (content.match('^priority=(.+)$', ) || [nil]) [1],
    gpgcheck: (content.match('^gpgcheck=(.+)$', ) || [nil]) [1],
    gpgkey: (content.match('^gpgkey=(.+)$', ) || [nil]) [1]
  }
end

repos = Find.find(starting_dir)
  .select { |e| e =~ /\.repo$/ }
  .map { |e| to_repo_hash(e) }

def to_sls_hash(path)
  {
    path: path,
    content: File.read(path)
  }
end

def to_declaration_hashes(sls_hash)

  # os_pool_repo:
  #   file.managed:
  #     - name: /etc/zypp/repos.d/openSUSE-Leap-42.3-Pool.repo
  #     - source: salt://repos/repos.d/openSUSE-Leap-42.3-Pool.repo
  #     - template: jinja

  raw_matches = sls_hash[:content].to_enum(:scan, /(.+):\n.*file.managed:\n((?:.* \- .*: .*\n)+)/).map { Regexp.last_match }
  raw_matches
    .select { |e| e[0] =~ /source: salt:\/\/.*.repo$/ }
    .map { |e| {
      id: e[1],
      name: e[2].match(/name: (.*)/)[1],
      source: e[2].match(/source: (.*)/)[1],
      full: e[0],
      path: sls_hash[:path]
    }}
end

slss = Find.find(starting_dir)
  .select { |e| e =~ /\.sls$/ }
  .map { |e| to_sls_hash(e) }

declarations = slss
  .map { |e| to_declaration_hashes(e) }
  .flatten

def to_substitution_hash(repos, declaration)
  matching_repo = repos
    .select { |e| Pathname.new(e[:path]).basename == Pathname.new(URI.parse(declaration[:source]).path).basename }
    .first

  if matching_repo.nil?
    return nil
  end

  gpgcheck = matching_repo[:gpgcheck]
  gpgkey = matching_repo[:gpgkey]
  priority = matching_repo[:priority]

  new_header = <<-STRING_END
#{declaration[:id]}:
  pkgrepo.managed:
    - baseurl: #{matching_repo[:baseurl]}
  STRING_END

  new = new_header +
    (if gpgcheck then "    - gpgcheck: #{gpgcheck}\n" else "" end) +
    (if gpgkey then "    - gpgkey: #{gpgkey}\n" else "" end) +
    (if priority then "    - priority: #{priority}\n" else "" end)

  {
    path: declaration[:path],
    original: declaration[:full],
    new: new
  }
end

substitutions = declarations
  .map { |e| to_substitution_hash(repos, e) }

substitutions.each do |s|
  text = File.read(s[:path])
  new_text = text.gsub(s[:original], s[:new])
  File.open(s[:path], "w") {|file| file.puts new_text }
end
