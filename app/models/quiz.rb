class Quiz < ActiveRecord::Base
  has_many :questions, dependent: :destroy
  has_many :categories, dependent: :destroy
  validates :name, presence: true
  validates :slug, presence: true
  alias_method :original_questions, :questions
  alias_method :original_categories, :categories

  before_validation do
    self.slug = name.parameterize
  end

  def to_param
    "#{name.parameterize}"
  end

  def self.from_param(param)
    find_by slug: param
  end

  def last?(question)
    questions.max_by{|q| q.sequence } == question
  end

  def questions
    original_questions.order "sequence asc"
  end

  def categories
    original_categories.order "id asc"
  end

  def get_results(answers)
    results = {}
    categories.each {|c| results[c.id] = 0 }
    answers.each do |k, v|
      question = questions.find{|q| q.id == k.gsub(/question_/, '').to_i }
      binding.pry if question.nil?
      answer = question.answers.find{|a| a.category_id == v }
      weight = question.weight || 1
      category = answer.category
      results[category.id] += weight
    end
    most_responded_category = results.max_by{|k, v| v }.first
    return categories.find most_responded_category
  end
end
