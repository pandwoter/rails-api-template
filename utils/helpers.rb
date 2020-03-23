# frozen_string_literal: true

# Deletes all lines after ---dunamic_setted_gems---
# (allows multiple usage of generator withot gem duplication)
module FileHelper
  def delete_dunamic_generated_gems(file_path)
    output_lines = File.readlines(file_path)

    output_lines.index { |l| l.starts_with?('#---dunamic_setted_gems---') }.yield_self do |start_line|
      output_lines.reject!.with_index { |_, index| index >= start_line }
    end

    File.open(file_path, 'w') do |f|
      output_lines.each do |line|
        f.write line
      end
    end
  end

  def copy_file_with_logging(src, dest, recursive: false)
    LOGGER.info("Copying #{src} to #{dest}...")
    send(recursive ? :cp_r : :cp, src, dest)
    LOGGER.info('Copied...')
  end
end
