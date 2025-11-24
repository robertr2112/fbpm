module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :Current.user

    def connect
      set_Current.user || reject_unauthorized_connection
    end

    private
      def set_Current.user
        if session = Session.find_by(id: cookies.signed[:session_id])
          self.Current.user = session.user
        end
      end
  end
end
