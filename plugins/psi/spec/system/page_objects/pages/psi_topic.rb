# frozen_string_literal: true

module PageObjects
  module Pages
    class PsiTopic < PageObjects::Pages::Base
      def visit_topic(topic)
        page.visit("/t/#{topic.slug}/#{topic.id}")
        self
      end

      def has_slider_widget?
        has_css?(".psi-slider-widget")
      end

      def has_no_slider_widget?
        has_no_css?(".psi-slider-widget")
      end

      def has_discrete_slider?
        has_css?(".psi-discrete-slider")
      end

      def has_vote_results?
        has_css?(".psi-vote-results")
      end

      def has_no_vote_results?
        has_no_css?(".psi-vote-results")
      end

      def has_stance_badge?(text)
        has_css?(".psi-stance-badge", text: text)
      end

      def has_responses_heading?(text)
        has_css?(".psi-vote-results__heading", text: text)
      end

      def click_slider_position(position)
        # Click the nth dot on the slider track (1-indexed)
        dots = all(".psi-discrete-slider__dot")
        dots[position - 1]&.click
        self
      end

      def has_selected_label?(text)
        has_css?(".psi-discrete-slider__selected-label", text: text)
      end

      def click_share_thoughts
        find(".psi-discrete-slider__share-thoughts").click
        self
      end

      def click_skip_and_submit_vote
        find(".psi-discrete-slider__skip-vote").click
        self
      end

      def click_update_response
        find(".psi-vote-results__update-link").click
        self
      end

      def has_bar_chart?
        has_css?(".psi-vote-results__chart")
      end

      def bar_percentage(position)
        find(".psi-vote-results__bar-group:nth-child(#{position}) .psi-vote-results__bar-pct").text
      end
    end
  end
end
