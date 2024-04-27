class Queue
  private getter conn : DB::Database
  private getter name : String

  def initialize(conn_string : String, name : String)
    @conn = DB.open(conn_string)
    @name = name
  end


  def create_queue()
    begin
      @conn.exec("SELECT pgmq.create($1)", @name)
    rescue exception
      raise "Error create queue: #{exception.message}"
    end
  end
end
