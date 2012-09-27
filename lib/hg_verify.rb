#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'yaml'
require 'optparse'
require 'hg_verify/repo_verifier'
require 'hg_verify/hg_option_parser'
require 'hg_verify/cli_runner'

HgVerify::Cli.run
