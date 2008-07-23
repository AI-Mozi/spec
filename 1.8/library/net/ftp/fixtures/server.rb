module NetFTPSpecs
  class DummyFTP
    attr_accessor :connect_message
    
    def initialize(port = 9921) 
      @server = TCPServer.new("localhost", port)
      
      @handlers = {}
      @commands = []
      @connect_message = nil
    end
    
    def serve_once
      @thread = Thread.new do
        @socket = @server.accept
        handle_request
        @socket.close
      end
    end
  
    def handle_request
      # Send out the welcome message.
      response @connect_message || "220 Dummy FTP Server ready!"
    
      begin
        loop do
          command = @socket.recv(1024)
          break if command.nil?

          command, argument = command.chomp.split(" ", 2)

          if command == "QUIT"
            self.response("221 OK, bye")
            break
          elsif proc_handler = @handlers[command.downcase.to_sym]
            if argument.nil?
              proc_handler.call(self)
            else
              proc_handler.call(self, argument)
            end
          else
            if argument.nil?
              self.send(command.downcase.to_sym)
            else
              self.send(command.downcase.to_sym, argument)
            end
          end
        end
      rescue => e
        self.error_response("Exception: #{e} #{e.backtrace.inspect}")
      end
    end
  
    def error_response(text)
      self.response("451 #{text}")
    end
  
    def response(text)
      @socket.puts(text) unless @socket.closed?
    end
  
    def stop
      @datasocket.close unless @datasocket.nil? || @datasocket.closed?
      @server.close
      @thread.join
    end
    
    
    ## 
    def handle(sym, &block)
      @handlers[sym] = block
    end
    
    def should_receive(method)
      @handler_for = method
      self
    end
  
    def and_respond(text)
      @handlers[@handler_for] = lambda { |s, *args| s.response(text) }
    end
    
    ##
    # FTP methods
    ##
    
    def abor
      self.response("226 Closing data connection. (ABOR)")
    end
    
    def acct(account)
      self.response("230 User '#{account}' logged in, proceed. (ACCT)")
    end
    
    def cdup
      self.response("200 Command okay. (CDUP)")
    end
    
    def cwd(dir)
      self.response("200 Command okay. (CWD #{dir})")
    end
    
    def dele(file)
      self.response("250 Requested file action okay, completed. (DELE #{file})")
    end
    
    def eprt(arg)
      _, _, host, port = arg.split("|")
      
      @datasocket = TCPSocket.new(host, port)
      self.response("200 port opened")
    end
    
    def list(folder)
      self.response("150 opening ASCII connection for file list")
      @datasocket.puts("-rw-r--r--  1 spec  staff  507 17 Jul 18:41 last_response_code.rb")
      @datasocket.puts("-rw-r--r--  1 spec  staff   50 17 Jul 18:41 list.rb")
      @datasocket.puts("-rw-r--r--  1 spec  staff   48 17 Jul 18:41 pwd.rb")
      @datasocket.close()
      self.response("226 transfer complete (LIST #{folder})")
    end
    
    def help(param = :default)
      if param == :default
        self.response("211 System status, or system help reply. (HELP)")
      else
        self.response("211 System status, or system help reply. (HELP #{param})")
      end
    end
    
    def stat
      self.response("211 System status, or system help reply. (STAT)")
    end
    
    def syst
      self.response("215 FTP Dummy Server (SYST)")
    end
    
    def type(type)
      self.response("200 TYPE switched to #{type}")
    end
    
    def user(name)
      self.response("230 User logged in, proceed. (USER #{name})")
    end
  end
end