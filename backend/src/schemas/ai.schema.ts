import Joi from 'joi';

export const generateResponseSchema = Joi.object({
  prompt: Joi.string().required().min(1).max(1000).messages({
    'string.empty': 'Prompt is required',
    'string.min': 'Prompt must be at least 1 character long',
    'string.max': 'Prompt cannot be longer than 1000 characters',
    'any.required': 'Prompt is required'
  }),
  context: Joi.object().optional()
});

export const analyzeTransactionsSchema = Joi.object({
  transactions: Joi.array().items(Joi.object()).min(1).required().messages({
    'array.base': 'Transactions must be an array',
    'array.min': 'At least one transaction is required',
    'any.required': 'Transactions array is required'
  })
});

export const detectFraudSchema = Joi.object({
  transaction: Joi.object().required().messages({
    'object.base': 'Transaction must be an object',
    'any.required': 'Transaction data is required'
  }),
  userHistory: Joi.array().items(Joi.object()).default([])
});

export const financialSummarySchema = Joi.object({
  financialData: Joi.object().required().messages({
    'object.base': 'Financial data must be an object',
    'any.required': 'Financial data is required'
  })
});
