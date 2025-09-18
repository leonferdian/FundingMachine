import { OpenAI } from '@langchain/openai';
import { PromptTemplate } from '@langchain/core/prompts';
import { StringOutputParser } from '@langchain/core/output_parsers';
import { RunnableSequence } from '@langchain/core/runnables';
import { ChatOpenAI } from '@langchain/openai';
import { HumanMessage, SystemMessage } from '@langchain/core/messages';
import config from '../config/config';

export class AIService {
  private model: ChatOpenAI;
  private static instance: AIService;

  private constructor() {
    this.model = new ChatOpenAI({
      openAIApiKey: config.openai.apiKey,
      modelName: config.openai.model,
      temperature: config.openai.temperature,
      maxTokens: config.ai.maxTokens,
      maxRetries: config.ai.maxRetries,
      timeout: config.ai.timeout,
    });
  }

  public static getInstance(): AIService {
    if (!AIService.instance) {
      AIService.instance = new AIService();
    }
    return AIService.instance;
  }

  /**
   * Generate AI response based on user input
   */
  public async generateResponse(
    prompt: string,
    context: Record<string, any> = {},
    systemMessage: string = 'You are a helpful AI assistant for the Funding Machine platform.'
  ): Promise<string> {
    try {
      const messages = [
        new SystemMessage(systemMessage),
        new HumanMessage(prompt)
      ];

      const response = await this.model.invoke(messages);
      return response.content.toString();
    } catch (error) {
      console.error('Error generating AI response:', error);
      throw new Error('Failed to generate AI response');
    }
  }

  /**
   * Analyze transaction patterns and provide insights
   */
  public async analyzeTransactionPatterns(userId: string, transactions: any[]): Promise<string> {
    const prompt = `Analyze the following transaction data for user ${userId} and provide insights:
    
    Transactions: ${JSON.stringify(transactions, null, 2)}
    
    Provide insights on:
    1. Spending patterns
    2. Potential savings opportunities
    3. Recommendations for optimizing funding sources
    `;

    return this.generateResponse(
      prompt,
      { transactions },
      'You are a financial analyst AI that provides insights on transaction patterns.'
    );
  }

  /**
   * Generate personalized funding recommendations
   */
  public async generateFundingRecommendations(userProfile: any): Promise<string> {
    const prompt = `Generate personalized funding recommendations for a user with the following profile:
    
    ${JSON.stringify(userProfile, null, 2)}
    
    Provide recommendations for:
    1. Best funding platforms based on their profile
    2. Expected returns and risks
    3. Time commitment required
    4. Any special requirements or qualifications
    `;

    return this.generateResponse(
      prompt,
      { userProfile },
      'You are an expert in passive income and funding strategies. Provide detailed, personalized recommendations.'
    );
  }

  /**
   * Detect potential fraud in transactions
   */
  public async detectFraud(transaction: any, userHistory: any[]): Promise<{
    isFraud: boolean;
    confidence: number;
    reasons: string[];
  }> {
    const prompt = `Analyze this transaction for potential fraud:
    
    Transaction: ${JSON.stringify(transaction, null, 2)}
    
    User History: ${JSON.stringify(userHistory, null, 2)}
    
    Return a JSON object with the following structure:
    {
      "isFraud": boolean,
      "confidence": number (0-1),
      "reasons": string[]
    }
    `;

    const response = await this.generateResponse(
      prompt,
      { transaction, userHistory },
      'You are a fraud detection AI. Analyze transactions for potential fraud and return a JSON response.'
    );

    try {
      return JSON.parse(response);
    } catch (error) {
      console.error('Failed to parse fraud detection response:', response);
      return {
        isFraud: false,
        confidence: 0,
        reasons: ['Unable to analyze transaction at this time.']
      };
    }
  }

  /**
   * Generate a summary of user's financial status
   */
  public async generateFinancialSummary(userId: string, financialData: any): Promise<string> {
    const prompt = `Generate a comprehensive financial summary for user ${userId} with the following data:
    
    ${JSON.stringify(financialData, null, 2)}
    
    Include:
    1. Current financial status
    2. Income vs. expenses
    3. Investment performance
    4. Recommendations for improvement
    `;

    return this.generateResponse(
      prompt,
      { financialData },
      'You are a financial advisor AI. Provide clear, actionable financial summaries and advice.'
    );
  }

  /**
   * Generate a response for user queries about the platform
   */
  public async handleUserQuery(query: string, userContext: any = {}): Promise<string> {
    const prompt = `User query: ${query}
    
    User context: ${JSON.stringify(userContext, null, 2)}
    
    Provide a helpful and accurate response to the user's query about the Funding Machine platform.`;

    return this.generateResponse(
      prompt,
      { query, userContext },
      'You are a helpful assistant for the Funding Machine platform. Provide accurate and friendly responses to user queries.'
    );
  }
}

// Export a singleton instance
export const aiService = AIService.getInstance();

export default aiService;
