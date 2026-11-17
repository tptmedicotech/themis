-- Allow runtime to delete knowledge documents (chunks cascade; replaces OpenAI file delete proxy).
grant delete on knowledge.documents to tpt_app;
