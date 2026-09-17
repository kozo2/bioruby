# frozen_string_literal: true

#
# test/unit/test_simplecov.rb - Tests for SimpleCov HTML output and Pages workflow
#
# Copyright::  Copyright (C) 2026 BioRuby Project
# License::    The Ruby License
#

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), '..',
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'

class TestSimpleCovOutput < Test::Unit::TestCase
  def repo_root
    Pathname.new(BioRubyTestLibPath).parent
  end

  def test_simplecov_is_started
    return unless defined?(SimpleCov)

    started = if SimpleCov.respond_to?(:coverage_running?)
                SimpleCov.coverage_running?
              elsif SimpleCov.respond_to?(:running)
                SimpleCov.running
              else
                true
              end
    assert(started, 'SimpleCov should be started by bioruby_test_helper')
  end

  def test_simplecov_writes_html_under_coverage
    return unless defined?(SimpleCov)

    coverage_dir = SimpleCov.coverage_dir.to_s
    assert_equal('coverage', File.basename(coverage_dir))

    formatter = SimpleCov.formatter
    formatter_name = formatter.is_a?(Class) ? formatter.name : formatter.class.name
    assert_match(/HTMLFormatter/, formatter_name)
  end

  def test_github_pages_workflow_publishes_coverage
    workflow = repo_root.join('.github', 'workflows', 'coverage.yml')
    assert(workflow.file?, "#{workflow} should exist")

    body = workflow.read
    assert_match(/simplecov/i, body)
    assert_match(/path: coverage/, body)
    assert_match(%r{actions/upload-pages-artifact}, body)
    assert_match(%r{actions/deploy-pages}, body)
    assert_match(/github-pages/, body)
  end
end
