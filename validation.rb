module Validation
  class ValidationError < StandardError; end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def fields
      @fields ||= {}
    end

    def fields=(val)
      @fields = val
    end

    def validate(key, **opts)
      option_types = {
        type: [Class, Module],
        presence: [TrueClass, FalseClass],
        format: [Regexp],
        enum: [Array]
      }
      opts.each do |opt_key, opt_val|
        unless (opt_type = option_types[opt_key.to_sym])
          raise ValidationError, "Invalid option '# {opt_key}'"
        end
        unless opt_type.include?(opt_val.class)
          raise ValidationError, "Option '#{opt_key}' must be of type '#{opt_type}'"
        end
      end
      fields[key.to_sym] = opts
    end
  end

  def validate!
    self.class.fields.each do |key, opts|
      opts.each do |opt_key, opt|
        unless Validator.send("validate_#{opt_key}", send(key), opt)
          raise ValidationError, "Attribute '#{key}' failed on '#{opt_key}'"
        end
      end
    end
    self
  end

  def valid?
    self.class.fields.all? do |key, opts|
      opts.all? do |opt_key, opt|
        Validator.send("validate_#{opt_key}", send(key), opt)
      end
    end
  end

  class Validator
    class << self
      private

      def validate_presence(field, opt)
        !(opt && (field.nil? || field == ''))
      end

      def validate_type(field, opt)
        field.nil? || field.is_a?(opt)
      end

      def validate_format(field, opt)
        field.nil? || Regexp.new(opt).match?(field)
      end

      def validate_enum(field, opt)
        field.nil? || opt.include?(field)
      end
    end
  end
end
