/*
  # Create user_codes table for collaborative code editor

  1. New Tables
    - `user_codes`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `code` (text, stores the code content)
      - `created_at` (timestamptz, creation timestamp)
      - `updated_at` (timestamptz, last update timestamp)
  
  2. Security
    - Enable RLS on `user_codes` table
    - Add policy for authenticated users to read their own code
    - Add policy for authenticated users to insert their own code
    - Add policy for authenticated users to update their own code
    - Add policy for authenticated users to delete their own code
*/

CREATE TABLE IF NOT EXISTS user_codes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  code text DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE user_codes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own code"
  ON user_codes FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own code"
  ON user_codes FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own code"
  ON user_codes FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own code"
  ON user_codes FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_codes_updated_at BEFORE UPDATE ON user_codes
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
