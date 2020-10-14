require "./validation.rb"

class Transaction
  include Validation

  attr_accessor :bookkeper, :planned_payee, :actual_payee, :size, :type, :code

  def initialize(**kwargs)
    kwargs.each do |key, val|
      send("#{key}=", val)
    end
  end

  validate :bookkeper, presence: false, type: String
  validate :planned_payee, presence: false, type: String
  validate :actual_payee, presence: true, type: String
  validate :size, presence: true, type: Numeric
  validate :type, presence: true, type: String, enum: ["salary", "bonus", "fine"]
  validate :code, presence: true, type: String, format: /^[0-9]{11}$/
end

trans = Transaction.new(
  planned_payee: "Lupa",
  actual_payee: "Pupa",
  type: "salary",
  size: 1337,
  code: "88005553535"
)

p trans.validate!
p trans.valid?
