require 'rubygems'

require 'jbuilder'
require 'nokogiri'
require 'net/http'
require 'uri'

class Repository
  attr_accessor :owner, :name, :description

  def initialize(owner, name, description)
    @owner = owner
    @name = name
    @description = description
  end

  def to_builder
    Jbuilder.new do |repo|
      repo.owner owner
      repo.name name
      repo.description description
    end
  end
end

def open(url)
  Net::HTTP.get(URI.parse(url))
end

def run_scraper
  languages = ['ABAP','ActionScript','Ada','Apex','AppleScript','Arc','Arduino','ASP','Assembly','Augeas','AutoHotkey','Awk','Boo','Bro','C','csharp','C++','Ceylon','CLIPS','Clojure','COBOL','CoffeeScript','ColdFusion','Common-Lisp','Coq','CSS','D','Dart','DCPU-16-ASM','DOT','Dylan','eC','Ecl','Eiffel','Elixir','Emacs-Lisp','Erlang','F#','Factor','Fancy','Fantom','Forth','FORTRAN','Go','Gosu','Groovy','Haskell','Haxe','Io','Ioke','Java','JavaScript','Julia','Kotlin','Lasso','LiveScript','Logos','Logtalk','Lua','M','Matlab','Max','Mirah','Monkey','MoonScript','Nemerle','Nimrod','Nu','Objective-C','Objective-J','OCaml','Omgrofl','ooc','Opa','OpenEdge-ABL','Parrot','Pascal','Perl','PHP','Pike','PogoScript','PowerShell','Processing','Prolog','Puppet','Pure-Data','Python','R','Racket','Ragel-in-Ruby-Host','Rebol','Rouge','Ruby','Rust','Scala','Scheme','Scilab','Self','Shell','Slash','Smalltalk','Squirrel','Standard-ML','SuperCollider','Tcl','Turing','TXL','TypeScript','Vala','Verilog','VHDL','VimL','Visual-Basic','Volt','wisp','XC','XML','XProc','XQuery','XSLT','Xtend']

  languages.each do |language|
    language.downcase!
    puts "Scraping: #{language}"

    repositories = scrape(language)

    repo_json = Jbuilder.encode do |json|
      json.repositories repositories.each do |repo|
        json.owner repo.owner
        json.name repo.name
        json.description repo.description
      end
    end

    write_string_to_file(language, repo_json)
  end

  puts 'All Done :D'
end

def write_string_to_file(name, my_string)
  json_file = File.new("json_files/#{name}.json", "w")
  json_file.puts my_string
  json_file.close
end

def scrape(language)
  page_content = open("https://github.com/trending?l=#{language}")

  page = Nokogiri::HTML( page_content )

  repos = page.css('li.repo-leaderboard-list-item')

  repositories = []

  repos.each do |repo|
    main_info = repo.css('a.repository-name')
    repo_owner = main_info.css('span.owner-name').text
    repo_name = main_info.css('strong').text
    repo_description = repo.css('p.repo-leaderboard-description').text

    repository = Repository.new(repo_owner, repo_name, repo_description)
    repositories << repository
  end

  repositories
end

run_scraper
