#!/usr/bin/env ruby

require 'watir'
require 'byebug'

raise ArgumentError, "ScrappyTranscribe requires a URL as first argument" if ARGV[0].nil?

class ScrappyTranscripter
  def initialize(url, browser = Watir::Browser.new)
    @url = url
    raise ArgumentError, "Must initialize ScrappyTranscripter with a URL" if @url.nil?

    @sleep_interval = 2.5

    @browser = browser
    @browser.goto(@url)
    @title = @browser.title

    trigger_cc_menu
    open_transcript_menu
    wait_until_transcript_menu_rendered
    create_transcript_array
  end

  def execute
    puts @title
    puts @transcript_array
  end

  private

    def trigger_cc_menu
      button = @browser.button(
        :"class" =>  ["style-scope", "yt-icon-button"],
        :"aria-label " => "More actions"
      )
      button.wait_until_present.click
    end

    def wait_until_transcript_menu_rendered
      @browser.div(
        :class => ["cue", "style-scope", "ytd-transcript-body-renderer"]
      ).wait_until_present
    end

    def open_transcript_menu
      @browser.element(
        :tag_name => "yt-formatted-string",
        :visible_text => "Open transcript"
      ).wait_until_present.click
    end

    def transcript
      @_transcript ||=
        @browser
        .text
        .slice(@browser.text.index(/Transcript/),
               @browser.text.index(/English \(auto\-generated\)/))
    end

    def create_transcript_array
      @transcript_array = transcript.split(/\n/)
    end
end

ScrappyTranscripter.new(ARGV[0]).execute
