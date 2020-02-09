module Zoom
  class Client    
    class TokenStorage

      class DefaultTokenStorage < Hash
        def get(k); self[k.to_s]; end
        def set(k, v); self[k.to_s] = v.to_s; end
        def del(*k)
          k.flatten.each{|_k| delete(_k) }
        end
      end

      # klass needs to be an object that supports the following methods:
      # get, set, del, keys, clear
      # 
      # By default it's a bonafied Hash
      # Redis is another example. Could be anything else that supports these methods
      attr_reader :klass

      MANAGED_KEYS = %w(access_token expires_in generated_at)

      def initialize(klass=nil)
        @klass = if klass.nil?
            puts "WARNING: using memory for as storage for tokens. It is preferred to use persistent storage like redis."
            DefaultTokenStorage.new
          else
            if klass.respond_to?(:set) && klass.respond_to?(:get)
              klass
            else
              raise "Invalid storage: #{klass}. Should support +get+ and +set+ methods"
            end
          end
      end

      def access_token
        get(:access_token)
      end

      def expires_in
        get(:expires_in){|v| v.to_i }
      end

      def generated_at
        get(:generated_at){|a| Time.parse(a) if a }
      end

      def clear
        @klass.del(*MANAGED_KEYS)
      end

      MANAGED_KEYS.each do |k|
        define_method("#{k}="){|v| set(k, v) }
      end

      def set_all(h)
        if h.is_a?(Hash)
          h.each{|k,v| set(k, v) }
        elsif h.is_a?(OpenStruct)
          set_all(h.to_h)
        else
          raise "Invalid input #{h.inspect}"
        end
      end

      private
      def get(key)
        raise "Invalid key" unless MANAGED_KEYS.include?(key.to_s)
        result = @klass.get(key)
        block_given? ? yield(result) : result
      end

      def set(key, value)
        raise "Invalid key" unless MANAGED_KEYS.include?(key.to_s)
        @klass.set(key.to_s, value.to_s)
      end
    end
  end
end