-- Arabic is the default language for the Arabic-first product.
alter table public.profiles alter column locale set default 'ar';
update public.profiles set locale = 'ar' where locale is null or locale = 'en';
