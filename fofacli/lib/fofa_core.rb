module Fofa

  class Exploit

    def initialize(info = {})
      @info = info
    end

    def excute_scansteps
      @info['ScanSteps'].each{|step|
        if !execute_step step
          return false #任何一个测试请求失败都返回FALSE
        end
      }
      true
    end

    def vulnerable
      excute_scansteps if @info['ScanStep']
    end

    def exploit
      false
    end

    private

    def execute_step(step)
      response = make_request(step['Request'])
      check_response(response, step['ResponseTest'])
    end

    def make_request(request)
      response = {error:false, errstring:'', body:'', head:''}
      response
    end

    def check_response(response, test)
      check_one(response, test)
    end

    def check_one(response, test)
      if test[:type]=='item'
        execute_item response, test
      else
        execute_group response, test
      end
    end

    def execute_group(response, test)
      case test[:operation]
        when 'AND'
          test[:checks].each{|t|
            return false unless check_one(response, t)
          }
        when 'OR'
          test[:checks].each{|t|
            return true if check_one(response, t)
          }
      end
    end

    def execute_item(response, test)
      case test[:varibale]
        when '$code'
          test_int(response.code, test[:operation], test[:value].to_i)
        when '$body'
          test_string(response.body, test[:operation], test[:value])
        when '$head'
          test_string(response.head, test[:operation], test[:value])
      end
    end

    def test_string(value, operation, expect_value)
      case operation
        when 'start_with'
          value.start_with?(expect_value)
        when 'end_with'
          value.end_with?(expect_value)
        when 'contains'
          value.include?(expect_value)
        when 'regex'
          value =~ Regexp.new(expect_value)
      end
    end

    def test_int(value, operation, expect_value)
      case operation
        when '=='
          value == expect_value
        when '!='
          value != expect_value
        when '>'
          value > expect_value
        when '<'
          value < expect_value
        when '>='
          value >= expect_value
        when '<='
          value <= expect_value
      end
    end
  end

end