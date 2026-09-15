export interface AppleTokens {
  refreshToken: string | null;
}
export interface AppleTokenClient {
  exchangeCode(code: string): Promise<AppleTokens>;
  revoke(refreshToken: string): Promise<void>;
}
