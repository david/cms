--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5 (Debian 17.5-1.pgdg120+1)
-- Dumped by pg_dump version 17.5 (Debian 17.5-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role AS ENUM (
    'admin',
    'member'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bible_verses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bible_verses (
    id bigint NOT NULL,
    book_usfm character varying(255) NOT NULL,
    chapter integer NOT NULL,
    verse_number integer NOT NULL,
    body text NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: bible_verses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bible_verses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bible_verses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bible_verses_id_seq OWNED BY public.bible_verses.id;


--
-- Name: blocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blocks (
    id bigint NOT NULL,
    liturgy_id bigint NOT NULL,
    song_id bigint,
    "position" integer NOT NULL,
    organization_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    subtitle character varying(255),
    title character varying(255),
    type character varying(255) NOT NULL,
    body text
);


--
-- Name: songs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.songs (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    body text,
    organization_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.blocks_id_seq OWNED BY public.songs.id;


--
-- Name: families; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.families (
    id bigint NOT NULL,
    designation character varying(255) NOT NULL,
    address text,
    organization_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: families_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.families_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: families_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.families_id_seq OWNED BY public.families.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    organization_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: liturgies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.liturgies (
    id bigint NOT NULL,
    service_on date,
    organization_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: liturgies_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.liturgies_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: liturgies_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.liturgies_blocks_id_seq OWNED BY public.blocks.id;


--
-- Name: liturgies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.liturgies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: liturgies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.liturgies_id_seq OWNED BY public.liturgies.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    hostname character varying(255) DEFAULT NULL::character varying NOT NULL
);


--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: prayer_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prayer_requests (
    id bigint NOT NULL,
    body text NOT NULL,
    user_id bigint NOT NULL,
    organization_id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    created_by_id bigint NOT NULL
);


--
-- Name: prayer_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.prayer_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: prayer_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.prayer_requests_id_seq OWNED BY public.prayer_requests.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying(255),
    confirmed_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    organization_id integer,
    name character varying(255) NOT NULL,
    phone_number character varying(255),
    family_id bigint NOT NULL,
    birth_date date,
    role public.user_role
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token bytea NOT NULL,
    context character varying(255) NOT NULL,
    sent_to character varying(255),
    authenticated_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL
);


--
-- Name: users_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_tokens_id_seq OWNED BY public.users_tokens.id;


--
-- Name: bible_verses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bible_verses ALTER COLUMN id SET DEFAULT nextval('public.bible_verses_id_seq'::regclass);


--
-- Name: blocks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks ALTER COLUMN id SET DEFAULT nextval('public.liturgies_blocks_id_seq'::regclass);


--
-- Name: families id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.families ALTER COLUMN id SET DEFAULT nextval('public.families_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: liturgies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.liturgies ALTER COLUMN id SET DEFAULT nextval('public.liturgies_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: prayer_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prayer_requests ALTER COLUMN id SET DEFAULT nextval('public.prayer_requests_id_seq'::regclass);


--
-- Name: songs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.songs ALTER COLUMN id SET DEFAULT nextval('public.blocks_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens ALTER COLUMN id SET DEFAULT nextval('public.users_tokens_id_seq'::regclass);


--
-- Name: bible_verses bible_verses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bible_verses
    ADD CONSTRAINT bible_verses_pkey PRIMARY KEY (id);


--
-- Name: songs blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.songs
    ADD CONSTRAINT blocks_pkey PRIMARY KEY (id);


--
-- Name: families families_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.families
    ADD CONSTRAINT families_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: blocks liturgies_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT liturgies_blocks_pkey PRIMARY KEY (id);


--
-- Name: liturgies liturgies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.liturgies
    ADD CONSTRAINT liturgies_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: prayer_requests prayer_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prayer_requests
    ADD CONSTRAINT prayer_requests_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_tokens users_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_pkey PRIMARY KEY (id);


--
-- Name: bible_verses_book_chapter_verse_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX bible_verses_book_chapter_verse_index ON public.bible_verses USING btree (book_usfm, chapter, verse_number);


--
-- Name: families_organization_id_designation_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX families_organization_id_designation_index ON public.families USING btree (organization_id, designation);


--
-- Name: groups_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX groups_organization_id_index ON public.groups USING btree (organization_id);


--
-- Name: liturgies_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX liturgies_organization_id_index ON public.liturgies USING btree (organization_id);


--
-- Name: liturgies_organization_id_service_on_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX liturgies_organization_id_service_on_index ON public.liturgies USING btree (organization_id, service_on);


--
-- Name: organizations_hostname_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX organizations_hostname_index ON public.organizations USING btree (hostname);


--
-- Name: prayer_requests_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX prayer_requests_organization_id_index ON public.prayer_requests USING btree (organization_id);


--
-- Name: prayer_requests_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX prayer_requests_user_id_index ON public.prayer_requests USING btree (user_id);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: users_family_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_family_id_index ON public.users USING btree (family_id);


--
-- Name: users_family_id_name_birth_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_family_id_name_birth_date_index ON public.users USING btree (family_id, name, birth_date);


--
-- Name: users_organization_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_organization_id_index ON public.users USING btree (organization_id);


--
-- Name: users_tokens_context_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_tokens_context_token_index ON public.users_tokens USING btree (context, token);


--
-- Name: users_tokens_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_tokens_user_id_index ON public.users_tokens USING btree (user_id);


--
-- Name: songs blocks_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.songs
    ADD CONSTRAINT blocks_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: blocks blocks_shared_content_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_shared_content_id_fkey FOREIGN KEY (song_id) REFERENCES public.songs(id);


--
-- Name: families families_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.families
    ADD CONSTRAINT families_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: groups groups_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: blocks liturgies_blocks_block_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT liturgies_blocks_block_id_fkey FOREIGN KEY (song_id) REFERENCES public.songs(id) ON DELETE CASCADE;


--
-- Name: blocks liturgies_blocks_liturgy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT liturgies_blocks_liturgy_id_fkey FOREIGN KEY (liturgy_id) REFERENCES public.liturgies(id) ON DELETE CASCADE;


--
-- Name: blocks liturgies_blocks_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT liturgies_blocks_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: liturgies liturgies_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.liturgies
    ADD CONSTRAINT liturgies_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: prayer_requests prayer_requests_created_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prayer_requests
    ADD CONSTRAINT prayer_requests_created_by_id_fkey FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: prayer_requests prayer_requests_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prayer_requests
    ADD CONSTRAINT prayer_requests_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: prayer_requests prayer_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prayer_requests
    ADD CONSTRAINT prayer_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users users_family_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_family_id_fkey FOREIGN KEY (family_id) REFERENCES public.families(id) ON DELETE CASCADE;


--
-- Name: users users_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: users_tokens users_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

INSERT INTO public."schema_migrations" (version) VALUES (20250426181150);
INSERT INTO public."schema_migrations" (version) VALUES (20250427142649);
INSERT INTO public."schema_migrations" (version) VALUES (20250427143602);
INSERT INTO public."schema_migrations" (version) VALUES (20250428113617);
INSERT INTO public."schema_migrations" (version) VALUES (20250429145956);
INSERT INTO public."schema_migrations" (version) VALUES (20250429164023);
INSERT INTO public."schema_migrations" (version) VALUES (20250429200224);
INSERT INTO public."schema_migrations" (version) VALUES (20250504143742);
INSERT INTO public."schema_migrations" (version) VALUES (20250505202451);
INSERT INTO public."schema_migrations" (version) VALUES (20250509164126);
INSERT INTO public."schema_migrations" (version) VALUES (20250511162023);
INSERT INTO public."schema_migrations" (version) VALUES (20250512180606);
INSERT INTO public."schema_migrations" (version) VALUES (20250512205212);
INSERT INTO public."schema_migrations" (version) VALUES (20250513111841);
INSERT INTO public."schema_migrations" (version) VALUES (20250513184139);
INSERT INTO public."schema_migrations" (version) VALUES (20250514145059);
INSERT INTO public."schema_migrations" (version) VALUES (20250514212755);
INSERT INTO public."schema_migrations" (version) VALUES (20250518112825);
INSERT INTO public."schema_migrations" (version) VALUES (20250520181113);
INSERT INTO public."schema_migrations" (version) VALUES (20250520183623);
INSERT INTO public."schema_migrations" (version) VALUES (20250521104156);
INSERT INTO public."schema_migrations" (version) VALUES (20250529143008);
INSERT INTO public."schema_migrations" (version) VALUES (20250529144128);
INSERT INTO public."schema_migrations" (version) VALUES (20250529151838);
INSERT INTO public."schema_migrations" (version) VALUES (20250529153711);
INSERT INTO public."schema_migrations" (version) VALUES (20250529164208);
INSERT INTO public."schema_migrations" (version) VALUES (20250529165125);
INSERT INTO public."schema_migrations" (version) VALUES (20250529165416);
INSERT INTO public."schema_migrations" (version) VALUES (20250529174600);
INSERT INTO public."schema_migrations" (version) VALUES (20250530132548);
INSERT INTO public."schema_migrations" (version) VALUES (20250605171914);
INSERT INTO public."schema_migrations" (version) VALUES (20250605173012);
INSERT INTO public."schema_migrations" (version) VALUES (20250605175322);
INSERT INTO public."schema_migrations" (version) VALUES (20250719142506);
INSERT INTO public."schema_migrations" (version) VALUES (20250719145605);
INSERT INTO public."schema_migrations" (version) VALUES (20250721090414);
INSERT INTO public."schema_migrations" (version) VALUES (20250721203328);
