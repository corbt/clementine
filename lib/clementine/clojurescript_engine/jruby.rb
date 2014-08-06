require "java"

$: << CLOJURESCRIPT_LIB

Dir.glob(CLOJURESCRIPT_LIB + "*.jar").each{|jar| CLASSPATH << jar}
%w{clj cljs}.each {|path| $CLASSPATH << CLOJURESCRIPT_HOME + "/src/" + path}

require 'clementine/clojurescript_engine/base'

%w{RT Keyword PersistentHashMap}.each do |name|
  java_import "clojure.lang.#{name}"
end

module Clementine
  class ClojureScriptEngine < ClojureScriptEngineBase
    def initialize(file, options)
      @file = file
      @options = options
    end

    def compile
      @options = default_opts.merge(Clementine.options) if Clementine.options
      cl_opts = PersistentHashMap.create(convert_options(@options))
      RT.loadResourceScript("cljs/closure.clj")
      builder = RT.var("cljs.closure", "build")
      builder.invoke(@file, cl_opts)
    end

    #private
    def convert_options(options)
      opts = {}
      options.each do |k, v|
        cl_key = Keyword.intern(Clementine.ruby2clj(k.to_s))
        case 
          when (v.kind_of? Symbol)
            cl_value = Keyword.intern(Clementine.ruby2clj(v.to_s))
          else
            cl_value = v
        end
        opts[cl_key] = cl_value
      end
      opts
    end
  end
end
