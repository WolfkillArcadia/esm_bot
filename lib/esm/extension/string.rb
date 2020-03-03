# frozen_string_literal: true

class String
  def to_ostruct
    JSON.parse(self, object_class: OpenStruct)
  end

  def to_h
    JSON.parse(self, symbolize_names: true)
  end

  def to_poptab
    # NumberHelper contains instance methods, but you can't initialize a module. Create an anonymous object to store the methods
    helper = Object.new.extend(ActionView::Helpers::NumberHelper)
    value = helper.number_to_currency(self, unit: t(:poptabs), format: "%n %u", precision: 0)

    # 1 will convert to "1 poptabs", this makes it "1 poptab"
    if self == "1"
      value.gsub(t(:poptabs), t(:poptab))
    else
      value
    end
  end

  def to_readable
    helper = Object.new.extend(ActionView::Helpers::NumberHelper)
    helper.number_with_delimiter(self)
  end
end
