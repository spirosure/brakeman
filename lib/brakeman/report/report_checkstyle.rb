# frozen_string_literal: true
require 'rexml/document'

class Brakeman::Report::Checkstyle < Brakeman::Report::Base
  SEVERITY = {
    1 => 'error',
    2 => 'warning',
    3 => 'info'
  }.freeze

  def generate_report
    document = REXML::Document.new
    document << REXML::XMLDecl.new('1.0', 'UTF-8')
    filling_checkstyle(document)
    document
  end

  private

  TREE_PATH = [
    :@absolute_engine_paths, :@additional_libs_path, :@controller_paths, :@initializer_paths, :@lib_files,
    :@model_paths, :@template_paths
  ].freeze

  def checked_files
    @checked_files = [].tap do |files|
      TREE_PATH.each { |paths| files << @app_tree.instance_variable_get(paths) }
    end.flatten
  end

  def filling_checkstyle(document)
    document.add_element('checkstyle').tap do |checkstyle|
      checked_files.each do |file_name|
        checkstyle.add_element('file', 'name' => file_name).tap do |file|
          filling_errors(file, file_name)
        end
      end
    end
  end

  def filling_errors(file, file_name)
    all_warnings.select { |warning| warning.file == file_name }.each do |error|
      attributes = { 'line' => error.line, 'severity' => SEVERITY[error.confidence], 'message' => error.message }
      file.add_element('error', attributes)
    end
  end
end
