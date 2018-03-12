class Appointment < ApplicationRecord
  belongs_to :service
  belongs_to :handler, polymorphic: true
  belongs_to :user

  def sanitize_attributes
    begin
    booking = self
    {
        id: booking.id,
        state: booking.state,
        book_time: booking.book_time,
        book_note: booking.book_notes,
        book_date: booking.book_date,
        payment_method: booking.payment_method,
        service: booking.service.sanitize_info,
        handler: {
            type: booking.handler.class.name,
            info: booking.handler.try(:simple_info)
        },
        user: booking.user.simple_info
    }
    rescue => e
      e
    end

  end

end
