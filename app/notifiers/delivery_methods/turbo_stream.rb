# frozen_string_literal: true

module Noticed
  module DeliveryMethods
    class TurboStream < Noticed::DeliveryMethods::Base
      def deliver
        return unless recipient.is_a?(User)
        
        # Get configuration
        channel_name = evaluate_option(:channel)
        stream_name = evaluate_option(:stream) || "notifications"
        action_type = evaluate_option(:action) || :append
        template_path = evaluate_option(:template) || "notifications/toast"
        
        # Broadcast to Turbo Stream
        Turbo::StreamsChannel.broadcast_action_to(
          channel_name,
          action: action_type,
          target: stream_name,
          partial: template_path,
          locals: {
            notification: notification,
            notification_type: notification.params[:notification_type] || 'success'
          }
        )
      end
      
      private
      
      def evaluate_option(name)
        option = config.public_send(name)
        option.respond_to?(:call) ? option.call(recipient) : option
      end
    end
  end
end