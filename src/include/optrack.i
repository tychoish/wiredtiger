/*-
 * Copyright (c) 2014-2017 MongoDB, Inc.
 * Copyright (c) 2008-2014 WiredTiger, Inc.
 *	All rights reserved.
 *
 * See the file LICENSE for redistribution information.
 */

static inline void
__wt_optrack_record_funcid(WT_SESSION_IMPL *session, uint64_t op_id,
			   void *func, size_t funcsize,
			   volatile bool *id_recorded)
{
	char endline[] = "\n";
	char id_buf[sizeof(uint64_t) + sizeof(char)+4];
	WT_CONNECTION_IMPL *conn;
	wt_off_t fsize;

	conn = S2C(session);

	__wt_spin_lock(session, &conn->optrack_map_spinlock);
	if (!*id_recorded) {
		WT_IGNORE_RET(snprintf(id_buf, sizeof(id_buf), "%p ",
				       (void*)op_id));
		WT_IGNORE_RET(__wt_filesize(session, conn->optrack_map_fh,
					    &fsize));
		WT_IGNORE_RET(__wt_write(session, conn->optrack_map_fh, fsize,
					 sizeof(id_buf)-1, id_buf));
		WT_IGNORE_RET(__wt_filesize(session, conn->optrack_map_fh,
					    &fsize));
		WT_IGNORE_RET(__wt_write(session, conn->optrack_map_fh,
					 fsize, funcsize-1, func));
		WT_IGNORE_RET(__wt_filesize(session, conn->optrack_map_fh,
					    &fsize));
		WT_IGNORE_RET(__wt_write(session, conn->optrack_map_fh,
					 fsize, sizeof(endline)-1, endline));
		*id_recorded = 1;
	}
	__wt_spin_unlock(session, &conn->optrack_map_spinlock);
}
