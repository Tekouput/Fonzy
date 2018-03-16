class BookingsRequest < ApplicationRecord
  belongs_to :handler, polymorphic: true
  belongs_to :user
  belongs_to :service

  def sanitize_attributes
    begin
      booking_request = self
      {
          id: booking_request.id,
          status: booking_request.status,
          book_time: booking_request.book_time,
          book_note: booking_request.book_notes,
          book_date: booking_request.book_date,
          # payment_method: booking_request.payment_method,
          service: booking_request.service.sanitize_info,
          handler: {
              type: booking_request.handler.class.name,
              info: booking_request.handler.try(:simple_info)
          },
          user: booking_request.user.simple_info
      }
    rescue => e
      e
    end
  end

end
